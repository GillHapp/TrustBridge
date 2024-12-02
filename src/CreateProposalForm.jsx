import React, { useState } from "react";
import "./CreateProposalForm.css";

const CreateProposalForm = ({ onSubmitProposal }) => {
    const [formData, setFormData] = useState({
        seller: "",
        tokenAddress: "",
        nativeAmount: "",
        goodsAmount: "",
    });

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({ ...formData, [name]: value });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmitProposal(formData);
    };

    return (
        <div className="form-container">
            <h2>Create Proposal</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="seller"></label>
                    <input
                        type="text"
                        id="seller"
                        name="seller"
                        placeholder="Enter seller's wallet address"
                        value={formData.seller}
                        onChange={handleChange}
                        required
                    />
                </div>
                <div className="form-group">
                    <label htmlFor="tokenAddress"></label>
                    <input
                        type="text"
                        id="tokenAddress"
                        name="tokenAddress"
                        placeholder="Enter ERC20 token address"
                        value={formData.tokenAddress}
                        onChange={handleChange}
                        required
                    />
                </div>
                <div className="form-group">
                    <label htmlFor="nativeAmount"></label>
                    <input
                        type="number"
                        id="nativeAmount"
                        name="nativeAmount"
                        placeholder="Enter amount in XFI"
                        value={formData.nativeAmount}
                        onChange={handleChange}
                        step="0.01"
                        required
                    />
                </div>
                <div className="form-group">
                    <label htmlFor="goodsAmount"></label>
                    <input
                        type="number"
                        id="goodsAmount"
                        name="goodsAmount"
                        placeholder="Enter goods token amount"
                        value={formData.goodsAmount}
                        onChange={handleChange}
                        required
                    />
                </div>
                <button type="submit" className="submit-btn">
                    Submit Proposal
                </button>
            </form>
        </div>
    );
};

export default CreateProposalForm;
